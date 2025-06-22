--[[
Unknown HERO Headhunter
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_UNKNOWN_HERO_CALLING)
	--If another monster(s) is Special Summoned while you control this monster (except during the Damage Step) (Quick Effect): You can banish 1 "HERO" card from your GY; destroy 1 card your opponent controls. Cards destroyed by this effect cannot activate their own effects that same turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e1:SetFunctions(
		aux.AlreadyInRangeEventCondition(),
		aux.BanishCost(aux.ArchetypeFilter(ARCHE_HERO),LOCATION_GRAVE,0,1,1,nil),
		s.destg,
		s.desop
	)
	c:RegisterEffect(e1)
	--If this card attacks an opponent's Special Summoned monster, this card gains 800 ATK/DEF for each Special Summoned monster on the field with different original names during damage calculation only.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
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
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.Destroy(tc,REASON_EFFECT)>0 and aux.BecauseOfThisEffect(e)(tc) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(STRING_CANNOT_TRIGGER)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end

--E2
function s.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and a==c and d and d:IsControler(1-tp) and d:IsSpecialSummoned()
end
function s.atkval(e,c)
	local ct=Duel.Group(aux.FaceupFilter(Card.IsSpecialSummoned),tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetClassCount(Card.GetOriginalCodeRule)
	return math.max(0,ct*800)
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