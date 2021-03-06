﻿<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="/WEB-INF/tlds/ttTagLibrary.tld" prefix="tt" %>

<style type="text/css">
	 @import "<c:url value='/css/layout/candidate_list.css'/>";
</style>

<script type="text/javascript">
	oltk.include('jquery/jquery.js');
	oltk.include('jquery/ui/ui.core.js');
	oltk.include('jquery/cluetip/jquery.cluetip.js');		
	
	$('#content').ready(function() {
		oltk.include('jquery/ui/ui.datepicker.js');
		oltk.include('openapplicant/admin/helper/jquery.tablesorter.min.js');
		
		$.tablesorter.addParser({ 
			id: 'lastName',
			is: function(s) {
	            // return false so this parser is not auto detected 
	            return false;
	        },
	        format: function(s) {
	            return $(s).find("strong").text().toLowerCase();
	        },
	        // set type, either numeric or text
	        type: 'text'
	    });

		$.tablesorter.addParser({
	        id: 'score',
	        is: function(s) {
	            return false;
	        },
	        format: function(s) {
	            return s.replace(/\u2014/, -1);
	        }, 
	        type: 'numericHack'
	    });

		if( $("#openapplicant_candidate_list tr").length > 1) {
			$("#openapplicant_candidate_list").tablesorter({
				sortList: [[1,0]],
				widgets: ['zebra'], //alternating row styles
				headers: {
					0: {sorter:'lastName'},
					2: {sorter:'score'},
					3: {sorter:'score'},
					4: {sorter:'score'},
					11: {sorter: false }
				}
			});
		}

		/* TODO: JQuery UI's datepicker has a DST bug in JQuery UI 1.5.2.  The bug 
		   should no longer appear after we upgrade to JQuery UI 1.6 or later. */
		$("#search_dates").datepicker({
			rangeSelect:true
		});
	
		$('.candidate_name').cluetip({
			width:425,
			cluetipClass:'history',
			ajaxSettings: {
				type: 'POST'
			}
		});
	
		$('.tooltip').each( function() {
			var activation = $(this).hasClass('hover') ? 'hover' : 'click';
			$(this).cluetip({
				activation: activation,
				width:175,
				cluetipClass:'jtip',
				local:true,
				arrows:true,
				closeText: '<img src="<c:url value="/img/jquery_cluetip/close-gray.png"/>"/>'
			});
		});
	});

</script>

<div id="content" style="width: 728px;">
	<table class="sortable" id="openapplicant_candidate_list" >
		<thead>
			<tr>
				<th class="header" id="name">Name</th>
				<th class="header" id="date">Date</th>
				<th class="header" id="screen">Screen</th>
				<th class="header" id="test">Exam</th>
				<th class="header" id="match">Match</th>
				<th class="header" id="status">Status</th>
				<th class="icon header"><img src="<c:url value='/img/table/phone.gif'/>" title="Sort by Contact Info"/></th>
				<th class="icon header"><img src="<c:url value='/img/table/email.gif'/>" title="Sort by Email"/></th>
				<th class="icon header"><img src="<c:url value='/img/table/resume.gif'/>" title="Sort by Resume"/></th>
				<th class="icon header"><img src="<c:url value='/img/table/analytics.gif'/>" title="Sort by Exam Results"/></th>
				<th class="icon header"><img src="<c:url value='/img/table/packet.gif'/>" title="Sort by Printable Packet"/></th>
				<th class="icon header"><img src="<c:url value='/img/table/archive.gif'/>" title="Archive"/></th>
			</tr>
		</thead>
		<tbody>
		<c:forEach var="c" items="${candidates}">
			<tr>
				<!--Column: name-->
				<td>
					<a class="candidate_name" href="<c:url value='detail?id=${c.id}'/>" rel="<c:url value='history?id=${c.id}'/>" title="History: ${tt:abbreviateTo(c.name.fullName,37)}">
						<c:choose>
							<c:when test="${!empty c.name.first}">
								<span><c:out value="${tt:abbreviateTo(c.name.first,14)}"/> <strong><c:out value="${tt:abbreviateTo(c.name.last,14)}"/></strong></span>
							</c:when>
							<c:otherwise>
								<span><i>Information Required</i> <img src="<c:url value='/img/candidate_icons/warning.png'/>"/></span>
							</c:otherwise>
						</c:choose>
					</a>
				</td>
				
				<!--Column: date-->
				<td><fmt:formatDate value="${c.entityInfo.createdDate.time}" type="date" dateStyle="short" timeStyle="short"/></td>
				
				<!--Column: screening score-->
				<td class="numerical">
					<c:choose>
						<c:when test="${!empty c.resume.screeningScore}">
							<c:out value="${c.resume.screeningScore}"/>
						</c:when>
						<c:otherwise>
							&mdash;
						</c:otherwise>
					</c:choose>
				</td>
				
				<!--Column: exam score-->
				<td class="numerical">
					<c:choose>
						<c:when test="${!empty c.lastSitting}">
							<c:out value="${c.lastSitting.score}"/>
						</c:when>
						<c:otherwise>
							&mdash;
						</c:otherwise>
					</c:choose>
				</td>
				
				<!--Column: match score-->
				<td class="numerical">
					<c:choose>
						<c:when test="${!empty c.matchScore}">
							<c:out value="${c.matchScore}"/>
						</c:when>
						<c:otherwise>
							&mdash;
						</c:otherwise>
					</c:choose>
				</td>
				
				<!--Column: status-->
				<td class="${c.status}"><c:out value="${tt:humanize(c.status)}"/></td>
				
				<!--Column: phone-->
				<td class="icon">
					<c:if test="${!empty c.cellPhoneNumber.number || !empty c.homePhoneNumber.number || !empty c.workPhoneNumber.number}">
					 	<a class="tooltip hover" rel="#phone_tooltip_${c.id}" title="<c:out value="${tt:abbreviateTo(c.name.first, 15)}"/>">
					 		<img src="<c:url value='/img/table/phone.gif'/>"/>
					 	</a>
					</c:if>
					<div style="display:none" id="phone_tooltip_${c.id}">
						<ul>
							<c:if test="${!empty c.cellPhoneNumber.number}">
								<li>
									(c) <c:out value="${c.cellPhoneNumber.number}"/>
								</li>
							</c:if>
							<c:if test="${!empty c.homePhoneNumber.number}">
								<li>
									(h) <c:out value="${c.homePhoneNumber.number}"/>
								</li>
							</c:if>
							<c:if test="${!empty c.workPhoneNumber.number}">
								<li>
									(w) <c:out value="${c.workPhoneNumber.number}"/>
								</li>
							</c:if>
						</ul>
					</div>
				</td>
				
				<!--Column: email-->
				<td class="icon">
					<c:if test="${!empty c.email}">
					 	<a href='mailto:<c:out value="${c.email}"/>'>
					 		<img src="<c:url value='/img/table/email.gif'/>" title="Send Email to ${tt:abbreviateTo(c.name.first,15)} at ${tt:abbreviateTo(c.email,30)}"/>
					 	</a>
					</c:if>
				</td>
				
				<!--Column: resume-->
				<td class="icon">
					<c:if test="${!empty c.resume}">
					 	<a href="<c:url value='/admin/file?guid=${c.resume.guid}' />" target="_blank">
					 		<img src="<c:url value='/img/table/resume.gif'/>" title="Download ${tt:abbreviateTo(c.name.first,15)}'s Resume"/>
					 	</a>
					</c:if>
				</td>
				
				<!--Column: analytics-->
				<td class="icon">
					<c:if test="${!empty c.lastSitting}">
						<a href="<c:url value='/admin/results/exam?s=${c.lastSitting.id}' />">
							<img src="<c:url value='/img/table/analytics.gif'/>" title="${tt:abbreviateTo(c.name.first,15)}'s Exam Results"/>
						</a>
					</c:if>
				</td>
				
				<!--Column: packet-->
				<td class="icon">
					<a href="<c:url value='/admin/report.pdf?candidate=${c.id}' />">
						<img src="<c:url value='/img/table/packet.gif'/>" title="${tt:abbreviateTo(c.name.first,15)}'s Packet"/>
					</a>
				</td>
				
				<!--Column: archive-->
				<td class="icon">
					<a class="tooltip" rel="#tooltip_${c.id }" title="Move to">
						<img src="<c:url value='/img/table/archive.gif'/>"/>
					</a>
					<div style="display:none" id="tooltip_${c.id}">
						<ul>
							<c:if test="${c.archived}">
								<li>
									<a href="<c:url value="updateStatus?id=${c.id}&status=${c.lastActiveStatus}&view_status=${view_status}&search_id=${searchId}"/>">
										<c:out value="${tt:humanize(c.lastActiveStatus)}"/>
									</a>
								</li>
							</c:if>
							<c:forEach var="status" items="${archivedStatuses}">
								<c:if test="${c.status != status}">
									<li>
										<a href="<c:url value="updateStatus?id=${c.id}&status=${status}&view_status=${view_status}&search_id=${searchId}"/>">
											<c:out value="${tt:humanize(status)}"/>
										</a>
									</li>
								</c:if>
							</c:forEach>
						</ul>
					</div>
				</td>
			</tr>
		</c:forEach>
		</tbody>
	</table>
	<c:if test="${empty candidates}">
		<div id="openapplicant_candidate_no_results">
			No results found.
		</div>
	</c:if>
</div>
