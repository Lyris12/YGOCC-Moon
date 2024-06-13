--[[
Curseflame Branding
Marchiatura Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--You can only control 1 "Curseflame Branding".
	c:SetUniqueOnField(1,0,id)
	--Activate this card by removing 5 Curseflame Counters from your field; place 1 Curseflame Counter on each face-up monster your opponent currently controls.
	local e0=c:Activation(false,true,nil,aux.RemoveCounterCost(COUNTER_CURSEFLAME,5,1,1),s.target,s.activate,true)
	e0:SetCategory(CATEGORY_COUNTER)
	c:RegisterEffect(e0)
	--[[Monsters your opponent controls with a Curseflame Counter gain the following effects.
	● Once per turn, during the Standby Phase, place 1 Curseflame Counter on this card.
	● If this card has 3 or more Curseflame Counters, change this card to Attack Position, also it cannot attack or change its battle position.
	● If this card leaves the field, inflict 300 damage to the controller of this card for each Curseflame Counter it had on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetOperation(s.ctop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetCondition(s.poscon)
	e3:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetCondition(s.poscon)
	e4:SetValue(1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetCondition(s.poscon)
	e5:SetValue(1)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(s.regop)
	aux.RegisterGrantEffect(c,LOCATION_SZONE,0,LOCATION_MZONE,s.granttg,e2,e3,e4,e5,e6)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,COUNTER_CURSEFLAME)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_CURSEFLAME,1)
	end
end

--E2
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_CURSEFLAME,1) then
		Duel.Hint(HINT_CARD,tp,id)
		c:AddCounter(COUNTER_CURSEFLAME,1)
	end
end

--E4
function s.poscon(e)
	return e:GetHandler():GetCounter(COUNTER_CURSEFLAME)>=3
end

--E6
function s.regop(e)
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_CURSEFLAME)
	if ct>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetLabel(ct)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_EVENT|RESET_TOFIELD)
		c:RegisterEffect(e2)
	end
end
function s.damop(e)
	local ct=e:GetLabel()
	Duel.Damage(e:GetHandler():GetPreviousControler(),ct*300,REASON_EFFECT)
end

--GRANT
function s.granttg(e,c)
	return c:HasCounter(COUNTER_CURSEFLAME)
end