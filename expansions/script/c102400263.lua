--created & coded by Lyris, art at http://deepseahydrothermal.weebly.com/uploads/6/0/1/8/60182675/830685177.jpg
--アーマリン公助
local s,id,o=GetID()
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
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.Draw(tp,2,REASON_EFFECT)~=2 then return end
	local dc=Duel.GetDecktopGroup(tp,1):GetFirst()
	for i=1,2 do
		if not (dc and Duel.SelectEffectYesNo(tp,e:GetHandler())) then break end
		Duel.DisableShuffleCheck()
		Duel.Destroy(dc,REASON_EFFECT)
		dc=Duel.GetDecktopGroup(tp,1):GetFirst()
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
