--Distruzione Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,34861)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(aux.LocationGroupCond(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),LOCATION_MZONE,0,1))
	e1:SetTarget(aux.Target(Card.IsFaceup,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,true,nil,CATEGORY_DESTROY))
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,34861),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end