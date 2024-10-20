--[[
Medicine of the Invernal
Medicina degli Invernali
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If your LP is lower than your opponent's, and all of the monsters you control are DARK monsters: Gain LP equal to the combined DEF of all DARK monsters you control.
	If you would gain an amount of LP that exceeds the difference between yours and your opponent's LP this way, your LP becomes equal to your opponent's, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		s.condition,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control a DARK "Number" Xyz Monster: You can banish this card; this turn, any battle damage your opponent would take from battles
	involving your attacking DARK "Number" Xyz Monsters is doubled.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(s.cfilter2,LOCATION_MZONE,0,1),
		aux.bfgcost,
		aux.DummyCost,
		s.damop
	)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:HasDefense()
end
function s.cfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp) and not Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetDefense)
	if chk==0 then
		return val>0
	end
	Duel.SetTargetPlayer(tp)
	local diff=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	if val>diff then
		Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local g=Duel.Group(s.filter,p,LOCATION_MZONE,0,nil)
	if #g<=0 then return end
	local val=g:GetSum(Card.GetDefense)
	local diff=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	if val>diff then
		Duel.SetLP(p,Duel.GetLP(1-p))
	else
		Duel.Recover(p,val,REASON_EFFECT)
	end
end

--E2
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.damtg)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterHint(tp,id,RESET_PHASE|PHASE_END,1,id,2,nil,e1)
end
function s.damtg(e,c)
	return Duel.GetAttacker()==c and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end