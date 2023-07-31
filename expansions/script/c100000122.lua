--The Boundless Bridge Between Brilliances
--Il Ponte Sconfinato Tra gli Splendori
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: Your opponent can make you draw 2 cards, and if they do, they negate this card's activation, and if they do that, they destroy it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DRAW|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(aux.MainPhaseCond(0),nil,nil,s.activate)
	c:RegisterEffect(e1)
	--[[During the Standby Phase: The turn player can destroy this card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetFunctions(aux.TurnPlayerCond(0),nil,s.dstg,s.dsop)
	c:RegisterEffect(e2)
	--[[This card is unaffected by its owner's card effects, except its own.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--[[Monsters on the field cannot be destroyed by card effects.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--[[Neither player can Tribute cards they do not control.]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_RELEASE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,0)
	e5:SetTarget(s.relval)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetTargetRange(0,1)
	e5x:SetTarget(s.relval2)
	c:RegisterEffect(e5x)
	--[[If a monster attacks a Defense Position monster that cannot be destroyed by that battle, it inflicts double piercing battle damage.]]
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.rdcon)
	e6:SetOperation(s.rdop)
	c:RegisterEffect(e6)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.rdcon)
	e6:SetOperation(s.rdop)
	c:RegisterEffect(e6)
end
--E1
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsChainNegatable(0) then
		if Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			if Duel.Draw(tp,2,REASON_EFFECT)>0 and Duel.NegateActivation(0) and c:IsRelateToChain() then
				Duel.Destroy(c,REASON_EFFECT)
			end
			return
		end
	end
end

--E2
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_DESTROY)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

--E3
function s.efilter(e,te)
	return te:GetOwnerPlayer()==e:GetHandler():GetOwner() and te:GetOwner()~=e:GetOwner()
end

--E4
function s.relval(e,c)
	return not c:IsControler(e:GetHandlerPlayer())
end
function s.relval2(e,c)
	return not c:IsControler(1-e:GetHandlerPlayer())
end

--E6
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetCode()==EVENT_CHAIN_SOLVED and Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then
		return false
	end
	local a,d = Duel.GetAttacker(),Duel.GetAttackTarget()
	if not a or a:HasFlagEffect(id) or not d or not d:IsDefensePos() then return false end
	local eset1={d:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
	for _,ce in ipairs(eset1) do
		if not d:IsImmuneToEffect(ce) and ce:Evaluate(a) then
			return true
		end
	end
	
	local eset2={d:IsHasEffect(EFFECT_INDESTRUCTABLE_COUNT)}
	for _,ce in ipairs(eset2) do
		if not d:IsImmuneToEffect(ce) and ce:CheckCountLimit(d:GetControler()) and ce:Evaluate(nil,REASON_BATTLE,a:GetControler()) then
			return true
		end
	end
	
	local eset3={d:IsHasEffect(EFFECT_INDESTRUCTABLE)}
	for _,ce in ipairs(eset3) do
		if not d:IsImmuneToEffect(ce) and ce:Evaluate(nil,REASON_BATTLE,a:GetControler()) then
			return true
		end
	end
	
	return false
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	a:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE,0,1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetValue(DOUBLE_DAMAGE)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
	a:RegisterEffect(e2)
end
--E7