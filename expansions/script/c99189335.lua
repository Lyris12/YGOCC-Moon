--Arcarum 0 - LO SCIOCCO
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--no damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,1)
	e1:SetCondition(cid.damcon)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e1x)
	--mill
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(cid.millcon)
	e2:SetTarget(cid.milltg)
	e2:SetOperation(cid.millop)
	c:RegisterEffect(e2)
	--spsummon as monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(cid.ecost)
	e3:SetTarget(cid.sptg)
	e3:SetOperation(cid.spop)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCost(cid.ecost)
	e4:SetTarget(cid.sctg)
	e4:SetOperation(cid.scop)
	c:RegisterEffect(e4)
	--MONSTER EFFECTS
	--indestructable
	local m1=Effect.CreateEffect(c)
	m1:SetType(EFFECT_TYPE_SINGLE)
	m1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	m1:SetRange(LOCATION_MZONE)
	m1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	m1:SetCondition(cid.mstatus)
	m1:SetValue(1)
	c:RegisterEffect(m1)
	local m2=m1:Clone()
	m2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(m2)
	--return to hand
	local m3=Effect.CreateEffect(c)
	m3:SetDescription(aux.Stringid(id,3))
	m3:SetCategory(CATEGORY_TOHAND)
	m3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	m3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	m3:SetRange(LOCATION_MZONE)
	m3:SetCountLimit(1)
	m3:SetCondition(cid.rtcon)
	m3:SetTarget(cid.rttg)
	m3:SetOperation(cid.rtop)
	c:RegisterEffect(m3)
end
--filters
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5477) and c:IsType(TYPE_MONSTER)
end
function cid.cfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_MONSTER)>0 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.millfilter(c)
	return c:IsSetCard(0x5477) and c:IsAbleToGrave()
end
function cid.scfilter(c)
	return c:IsCode(99189346) and c:IsAbleToHand()
end
--no damage
function cid.damcon(e)
	return Duel.IsExistingMatchingCard(cid.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--mill
function cid.millcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,e:GetHandler())
end
function cid.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.millfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cid.millop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.millfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--spsummon as monster
function cid.ecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x5477,0x21,0,0,1,RACE_WARRIOR,ATTRIBUTE_EARTH) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x5477,0x21,0,0,1,RACE_WARRIOR,ATTRIBUTE_EARTH)  then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	if Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP)~=0 then
		if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
			e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,Duel.GetTurnCount())
		else
			e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,0)
		end
	end
end
--search
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--monster status condition
function cid.mstatus(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
--return to hand
function cid.rtcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(id+100)
	return tid and tid~=Duel.GetTurnCount() and Duel.GetTurnPlayer()==tp and cid.mstatus(e,tp,eg,ep,ev,re,r,rp)
end
function cid.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.rtop(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():IsControler(tp) or e:GetHandler():IsLocation(LOCATION_MZONE)) then return end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end