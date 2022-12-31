--MMS - Cavalcatore
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:SummonedTrigger(false,true,true,false,0,CATEGORY_SPECIAL_SUMMON,true,true,
		nil,
		nil,
		aux.SSTarget(s.spfilter,LOCATION_HAND+LOCATION_REMOVED,LOCATION_REMOVED),
		aux.SSOperation(s.spfilter,LOCATION_HAND+LOCATION_REMOVED,LOCATION_REMOVED)
	)
	--tohand
	c:Ignition(1,CATEGORY_TOHAND+CATEGORY_ATKCHANGE,EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE,true,
		nil,
		nil,
		aux.Target(aux.ToHandFilter(Card.IsSpellTrapOnField),LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_TOHAND,nil,nil,aux.HandlerInfo(CATEGORY_ATKCHANGE,300)),
		aux.CreateOperation(
			aux.SendToHandOperation(SUBJECT_IT),
			CONJUNCTION_AND_IF_YOU_DO,
			aux.UpdateATKOperation(SUBJECT_THIS_CARD,300,RESET_PHASE+PHASE_END)
		)
	)
end
function s.spfilter(c)
	return c:NotBanishedOrFaceup() and c:IsSetCard(0xd71)
end