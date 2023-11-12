--Zombie Soul Corruption
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--selfdestroy
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCode(EFFECT_SELF_DESTROY)
	e0:SetCondition(s.descon)
	c:RegisterEffect(e0)
	--Activation Cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Extra Deck Type Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
	--Discard to draw 1
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.dcost)
	e3:SetTarget(s.dtarget)
	e3:SetOperation(s.dop)
	c:RegisterEffect(e3)
	--Zombies gain ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e4d=e4:Clone()
	e4d:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4d)
end
--e0 group
function s.desfilter(c)
	return c:IsFaceup() and c:IsCode(04064256)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.desfilter,e:GetHandler():GetControler(),LOCATION_FZONE,0,1,nil)
end
--e1 group
function s.costfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,3,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
--e3 group
function s.costfilter2(c,tp)
	return c:IsDiscardable()
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	local ct=1
	if Duel.IsPlayerCanDraw(tp,3) then ct=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	e:SetLabel(Duel.SendtoGrave(g:Select(tp,1,ct,nil),REASON_DISCARD+REASON_COST))
end
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--e4 Group
function s.atkcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil,RACE_ZOMBIE)*50
end