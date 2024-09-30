--created by Slick, coded by Lyris
--Kronologistical Nightmare
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,212111808)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SHOPT(true)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT(true)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCondition(s.tdcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_DRIVE) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #tg==0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	aux.GCheckAdditional=aux.dlvcheck
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,1,#tg)
	aux.GCheckAdditional=aux.TRUE
	if not rg then return end
	local ct=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	if ct<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=tg:Select(tp,1,1,nil)
	Duel.HintSelection(sg)
	Duel.BreakEffect()
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.cfilter(c,tp)
	local code1,code2=c:GetPreviousCodeOnField()
	return (code1==212111808 or code2==212111808) and c:GetReasonPlayer()==1-tp
		and (c:IsLocation(LOCATION_REMOVED) or c:IsControler(tp))
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_DRIVE) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(Duel.GetTargetsRelateToChain(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
