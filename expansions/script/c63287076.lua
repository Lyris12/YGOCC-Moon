--Voltech Boomerang
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,1,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST):SetValue(SUMMON_VALUE_SELF)
	--no response on summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	local e1y=e1:Clone()
	e1y:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1y)
	local e1z=Effect.CreateEffect(c)
	e1z:Desc(3)
	e1z:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1z:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1z:SetRange(LOCATION_MZONE)
	e1z:SetCode(EVENT_CHAIN_END)
	e1z:SetOperation(s.limop2)
	c:RegisterEffect(e1z)
	--gain effect
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.eqmatfilter(c)
	return c:IsFaceup() and c:IsFusionCode(63287017)
end
function s.matfilter(c)
	return c:IsFusionCode(63287014) and c:GetEquipGroup() and c:GetEquipGroup():IsExists(s.eqmatfilter,1,nil)
end

function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	e:GetHandler():ResetFlagEffect(id)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
function s.filter(c)
	return not c:HasFlagEffect(id)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and not chkc:HasFlagEffect(id) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetChainLimit(aux.FALSE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		aux.CannotBeEDMaterial(tc,nil,nil,false,RESET_EVENT+RESETS_STANDARD,c,EFFECT_FLAG_SET_AVAILABLE)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end