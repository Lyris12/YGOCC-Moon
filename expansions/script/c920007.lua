--[[
Curseflame Lifetap
Vitaestrazione Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	c:Activation(true)
	--You can only control 1 "Curseflame Lifetap".
	c:SetUniqueOnField(1,0,id)
	--Once per turn, during your Standby Phase: Gain 300 LP for each Curseflame Counter on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(aux.TurnPlayerCond(0),nil,s.lptg,s.lpop)
	c:RegisterEffect(e1)
	--Each time a monster(s) your opponent controls with a Curseflame Counter is destroyed by battle or card effect, immediately inflict damage to your opponent equal to their combined original ATK or DEF (for each monster choose whichever is higher, or any if tied).
	aux.RegisterCountersBeforeLeavingField(c,COUNTER_CURSEFLAME,LOCATION_SZONE,nil,id)
	aux.RegisterMaxxCEffect(c,id+100,nil,LOCATION_SZONE,EVENT_DESTROYED,s.damcon,s.damopOUT,s.damopIN,s.flaglabel)
end
--E1
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*300)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	Duel.Recover(p,ct*300,REASON_EFFECT)
end

--E2
function s.cfilter(c,p)
	return c:GetPreviousLocation()==LOCATION_MZONE and c:GetPreviousControler()==p and c:HasFlagEffect(id) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.choosestat(c)
	return math.max(c:GetTextAttack(),c:GetTextDefense())
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:Filter(s.cfilter,nil,1-tp):GetSum(s.choosestat)
end
function s.damopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:Filter(s.cfilter,nil,1-tp):GetSum(s.choosestat)
	Duel.Damage(1-tp,ct,REASON_EFFECT)
end
function s.damopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id+100)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Damage(1-tp,ct,REASON_EFFECT)
end