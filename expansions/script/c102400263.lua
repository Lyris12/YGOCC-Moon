--created & coded by Lyris, art at http://deepseahydrothermal.weebly.com/uploads/6/0/1/8/60182675/830685177.jpg
--アーマリンの公助
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(s.cfilter,1,nil,tp) end)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsSetCard(0xa6c) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsOnField())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	if Duel.Destroy(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil),REASON_EFFECT)==0 or Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,1101) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		Duel.Destroy(g:Select(tp,1,1,nil),REASON_EFFECT)
	end
end
function s.cfilter(c,tp)
	return c:GetSummonPlayer()~=tp
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and eg:IsExists(aux.AND(s.cfilter,Card.IsAbleToGrave),1,nil,tp) end
	Duel.SetTargetCard(eg:Filter(s.cfilter,nil,tp))
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg:Filter(aux.AND(s.cfilter,Card.IsAbleToGrave),nil,tp),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	if Duel.Destroy(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil),REASON_EFFECT)==0 then return end
	Duel.SendtoGrave(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):FilterSelect(tp,aux.AND(Card.IsRelateToEffect,Card.IsAbleToGrave),1,1,nil,e),REASON_EFFECT)
end
