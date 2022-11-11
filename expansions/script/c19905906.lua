--MMS - Trono
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.mfilter1,aux.Filter(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),true)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,true,
		nil,
		nil,
		aux.Target(aux.TRUE,0,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation(SUBJECT_IT)
	)
	--attack while in DEF
	c:CanAttackWhileInDefensePosition()
	--negate
	c:CreateNegateEffect(true,1,nil,1,LOCATION_MZONE,true,
		nil,
		aux.ToDeckCost(s.cfilter,LOCATION_REMOVED)
	)
end
function s.mfilter1(c)
	return c:IsFusionSetCard(0xd71) and c:IsFusionType(TYPE_MONSTER)
end
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsFaceup() then return false end
	local rtype=(re:GetActiveType()&0x7)
	return c:IsType(rtype)
end