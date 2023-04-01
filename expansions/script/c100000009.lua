--Phoenix Boss Spirit
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(Card.IsRace,RACE_BEAST),2,2)
	--After this card was Synchro Summoned, you cannot Special Summon monsters for the rest of this turn, except Beast monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--[[If this card was Synchro Summoned using 4 monsters with different Attributes as material, it cannot be destroyed by card effects,
	also your opponent cannot target this card with card effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.econ)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
	--material check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.matcheck)
	c:RegisterEffect(e3)
	--Gains 500 ATK for each Attribute on the field.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--If this card is destroyed: You can Special Summon this card.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:HOPT()
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_BEAST)
end

function s.econ(e)
	return e:GetHandler():HasFlagEffect(id)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if #g==4 and g:GetClassCount(Card.GetAttribute)==4 then
		c:RegisterFlagEffect(id,(RESET_EVENT|RESETS_STANDARD)&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end

function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return aux.GetAttributeCount(g)*500
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end