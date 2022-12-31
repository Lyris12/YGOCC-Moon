--Halgerdi, Demon Kitsune of Seki
--Script by XGlitchy30
function c88523896.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.Tuner(c88523896.tunermat),aux.Tuner(c88523896.tunermat),nil,aux.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--synchro summon event
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523896,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88523896.syscon)
	e1:SetTarget(c88523896.systg)
	e1:SetOperation(c88523896.sysop)
	c:RegisterEffect(e1)
	--deck destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88523896,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c88523896.systg)
	e2:SetOperation(c88523896.sysop)
	c:RegisterEffect(e2)
	--battle destruction
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88523896,2))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c88523896.bdcon)
	e3:SetTarget(c88523896.bdtg)
	e3:SetOperation(c88523896.bdop)
	c:RegisterEffect(e3)
end
--materials
function c88523896.tunermat(c)
	return c:IsRace(RACE_BEASTWARRIOR)
end
--filters
function c88523896.matcheck(c)
	return not c:IsSetCard(0x215a)
end
--synchro summon event
function c88523896.syscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and not c:GetMaterial():IsExists(c88523896.matcheck,1,nil)
end
function c88523896.systg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function c88523896.sysop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end
--battle destruction
function c88523896.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
		and Duel.IsPlayerCanDiscardDeck(1-tp,1)
end
function c88523896.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function c88523896.bdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end