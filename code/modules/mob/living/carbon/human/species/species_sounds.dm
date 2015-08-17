/datum/species_sounds
	var/list/m_scream = null
	var/list/f_scream = null

	var/list/m_gasp = null
	var/list/f_gasp = null

	var/list/m_cough = null
	var/list/f_cough = null

/datum/species_sounds/proc/getScream( var/gender = null )
	if( gender == FEMALE && f_scream )
		return pick( f_scream )

	if( m_scream ) // male screams are default, down with the patriarchy
		return pick( m_scream )

/datum/species_sounds/proc/getGasp( var/gender = null )
	if( gender == FEMALE && f_gasp )
		return pick( f_gasp )

	if( m_gasp )
		return pick( m_gasp )

/datum/species_sounds/proc/getCough( var/gender = null )
	if( gender == FEMALE && f_cough )
		return pick( f_cough )

	if( m_cough )
		return pick( m_cough )