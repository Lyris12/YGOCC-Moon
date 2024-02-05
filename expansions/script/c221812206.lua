--[[
Viravolvesca
Viravolvesca
Original Script by: Lyris
Rescripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	--destroy and negate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VIRAVOLVE) and c:GetColumnGroup():IsExists(aux.NegateAnyFilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	local dg=g:GetFirst():GetColumnGroup():Filter(aux.NegateAnyFilter,g)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,dg,#dg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local vc=Duel.GetFirstTarget()
	local cg=vc:GetColumnGroup():Filter(aux.NegateAnyFilter,vc):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if vc:IsRelateToChain() and Duel.Destroy(vc,REASON_EFFECT)~=0 and #cg>0 then
		Duel.BreakEffect()
		for tc in aux.Next(cg) do
			Duel.Negate(tc,e,RESET_PHASE|PHASE_END,false,false,TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
		end
	end
end
