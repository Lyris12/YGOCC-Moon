--[[
Unknown HERO Lockdown
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_UNKNOWN_HERO_CALLING)
	--During the Main Phase (Quick Effect): You can target face-up cards your opponent controls, up to the number of "HERO" monsters you control with different original names; negate their effects until the end of the turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetFunctions(aux.MainPhaseCond(),nil,s.negtg,s.negop)
	c:RegisterEffect(e1)
	--If this card attacks an opponent's monster, that monster loses 1000 ATK/DEF during damage calculation only.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(-1000)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e2x=e2:UpdateDefenseClone(c)
	e2x:SetLabelObject(e2)
	--If this card is used as Fusion or Synchro Material for the Summon of a "HERO" monster: That monster gains this card's other effects.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetLabelObject(e2x)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
--E1
function s.filter(c)
	return c:IsSetCard(ARCHE_HERO) and c:IsFaceup()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	local ct=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetOriginalCodeRule)
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
function s.discheck(c,e)
	return c:IsFaceup() and c:IsCanBeDisabledByEffect(e,false)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetsRelateToChain():Filter(s.discheck,nil,e)
	if #tg>0 then
		Duel.Negate(tg,e,RESET_PHASE|PHASE_END)
	end
end

--E2
function s.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and a==c and d and d:IsControler(1-tp)
end
function s.atktg(e,c)
	return c==Duel.GetAttackTarget()
end

--E3
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_FUSION|REASON_SYNCHRO)>0 and e:GetHandler():GetReasonCard():IsSetCard(ARCHE_HERO)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetReasonCard())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if rc:IsRelateToChain() and rc:IsFaceup() then
		rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		local e2x=e:GetLabelObject()
		local e2=e2x:GetLabelObject()
		local e1=e2:GetLabelObject()
		local reg1,reg2,reg3=e1:Clone(),e2:Clone(),e2x:Clone()
		reg1:SetReset(RESET_EVENT|RESETS_STANDARD)
		reg2:SetReset(RESET_EVENT|RESETS_STANDARD)
		reg3:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(reg1,true)
		rc:RegisterEffect(reg2,true)
		rc:RegisterEffect(reg3,true)
		if not rc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			rc:RegisterEffect(e2,true)
		end
	end
end