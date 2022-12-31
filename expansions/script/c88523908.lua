--Krasae, Demon Kitsune of Seki
--Script by XGlitchy 30
function c88523908.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.Tuner(c88523908.tunermat),aux.Tuner(c88523908.tunermat),nil,aux.NonTuner(nil),2,99)
	c:EnableReviveLimit()
	--synchro summon event
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523908,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88523908.syscon)
	e1:SetTarget(c88523908.systg)
	e1:SetOperation(c88523908.sysop)
	c:RegisterEffect(e1)
	--cannot release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetTarget(c88523908.sumlimit)
	c:RegisterEffect(e2)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_SINGLE)
	e3x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetValue(1)
	c:RegisterEffect(e3x)
	--deck destruction
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88523908,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c88523908.ddtg)
	e4:SetOperation(c88523908.ddop)
	c:RegisterEffect(e4)
end
--materials
function c88523908.tunermat(c)
	return c:IsRace(RACE_BEASTWARRIOR)
end
--filters
function c88523908.matcheck(c)
	return not c:IsSetCard(0x215a)
end
--synchro summon event
function c88523908.syscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and not c:GetMaterial():IsExists(c88523908.matcheck,1,nil)
end
function c88523908.systg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function c88523908.sysop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,4,REASON_EFFECT)
end
--cannot release
function c88523908.sumlimit(e,c,tp,sumtp)
	if not c then return false end
	return c==e:GetHandler()
end
--deck destruction
function c88523908.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function c88523908.ddop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end