--created by Swag, coded by Lyris
--The Ængelic Final Battlefield
local s,id,o=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,0,3,nil) end)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xae6))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e0:SetOperation(s.act)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCondition(function(_,tp) return eg:IsExists(Card.IsFacedown,1,nil) and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0xae6) end)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsLevelBelow(5) and c:IsSetCard(0xae6) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.rfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemove()
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SendtoHand(sc,nil,REASON_EFFECT)==0 or not sc:IsLocation(LOCATION_HAND) then return end
		Duel.ConfirmCards(1-tp,sc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_DECK,0,1,1,nil,sc:GetCode()),POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
