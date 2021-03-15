--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PSYCHO),3)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetValue(function(e,tc) return Duel.GetMatchingGroupCount(function(fc) return fc:GetSequence()<5 end,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil)*500 end)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(function(e,tc) return s.repfilter(tc,LOCATION_ONFIELD) end)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.repfilter(c,loc)
	return c:IsLocation(loc) and not c:IsForbidden()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,LOCATION_MZONE) end
	local g=eg:Filter(s.repfilter,c,LOCATION_MZONE)
	for tc in aux.Next(g) do
		if Duel.Equip(tp,tc,c,true,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
	Duel.EquipComplete()
	return true
end
function s.eqlimit(e,c)
	return c==e:GetOwner()
end
function s.cfilter(c,tc)
	return c:GetEquipTarget()==tc and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,5,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,5,5,nil,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,LOCATION_HAND)
	if chk==0 then return h>0 and Duel.IsPlayerCanDiscardDeck(tp,h) and Duel.IsPlayerCanDiscardDeck(1-tp,h) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	local ct=#g
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	Duel.BreakEffect()
	Duel.ConfirmDecktop(tp,ct)
	Duel.ConfirmDecktop(1-tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)+Duel.GetDecktopGroup(1-tp,ct)
	local tg=g:Filter(Card.IsRace,nil,RACE_PSYCHO)
	if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REVEAL)==0 then Duel.ShuffleDeck(tp) Duel.ShuffleDeck(1-tp) return end
	local pt=tg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if pt>0 then
		Duel.Draw(tp,pt,REASON_EFFECT)
		Duel.Draw(1-tp,pt,REASON_EFFECT)
	end
end
