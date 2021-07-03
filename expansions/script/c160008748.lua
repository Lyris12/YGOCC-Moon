--Care Werewolf
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
   aux.AddEvoluteProc(c,nil,6,cid.filter1,2)
		local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.drcon)
	--e1:SetCost(cid.drcost)
	e1:SetTarget(cid.drtg)
	e1:SetOperation(cid.drop)
	c:RegisterEffect(e1)
  --attack up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,0x1e0)
	e2:SetCost(cid.cost)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_BEAST) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function cid.filter(c)
	return not c:IsRace(RACE_BEAST)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if g:IsExists(Card.IsRace,1,nil,RACE_BEAST) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)
			local g1=g:Select(p,1,1,nil)
			if g1:GetFirst():IsRace(RACE_BEAST) then
				g:RemoveCard(g1:GetFirst())
			else
				g:Remove(cid.filter,nil)
			end
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)
			local g2=g:Select(p,1,1,nil)
			g1:Merge(g2)
			Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)
		else
			Duel.ConfirmCards(1-p,g)
			Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		end
	end
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
  
 e:GetHandler():RemoveEC(tp,3,REASON_COST)

end

function cid.operation(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(cid.atkval)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
function cid.atkfilter(c)
	return c:IsRace(RACE_BEAST)
end
function cid.atkval(e,c)
	return Duel.GetMatchingGroupCount(cid.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*-300
end