--[[
Curseflame Bind
Vincolo Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect: Remove 3 Curseflame Counters from anywhere on the field; negate the activation, and if you do, your opponent cannot activate cards, or effects of cards, with the same original name as that card until your next Standby Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(
		s.condition,
		aux.RemoveCounterCost(COUNTER_CURSEFLAME,3,1,1),
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY, except the turn it was sent there: You can Tribute 1 face-up card on either field with 3 or more Curseflame Counters; Set this card, but banish it when it leaves the field, unless the Tributed card had 6 or more Curseflame Counters.
	aux.EnableGlobalEffectTributeOppoCost()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(
		aux.AND(aux.exccon,aux.MainPhaseCond(0)),
		aux.TributeGlitchyCost(s.cfilter,1,1,nil,false,true,aux.TRUE,LOCATION_SZONE,LOCATION_SZONE,nil,nil,nil,s.pretribute),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local ec=re:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetLabel(ec:GetOriginalCode())
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_TURN_SELF,Duel.GetNextPhaseCount(PHASE_STANDBY,tp))
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():GetOriginalCode()==e:GetLabel()
end

--E2
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:HasCounter(COUNTER_CURSEFLAME) and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or (c:IsInBackrow() and c:IsControler(tp)))
end
function s.pretribute(rg,e,tp,eg,ep,ev,re,r,rp)
	local tc=rg:GetFirst()
	e:SetLabel(tc:GetCounter(COUNTER_CURSEFLAME))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsSSetable(e:IsCostChecked())
	end
	local val=(e:IsCostChecked() and e:GetLabel()>=6) and 1 or 0
	Duel.SetTargetParam(val)
	Duel.SetCardOperationInfo(c,CATEGORY_LEAVE_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		if Duel.GetTargetParam()==1 then
			Duel.SSet(tp,c)
		else
			Duel.SSetAndRedirect(tp,c,e)
		end
	end
end