--created by Jake, art from Cardfight!! Vanguard's "Battlefield Storm, Sagramore"
--Dawn Blader - Lion
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_DISCARD)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetCondition(s.con)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.slevel)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsRace(RACE_WARRIOR) end)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
end
function s.slevel(e,c)
	local lv=e:GetHandler():GetLevel()
	return (0x2<<16)+lv
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local rs=r&0xc0
	local res=rs~=0 and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613)
	if rs&REASON_COST==REASON_COST then res=res and re:IsHasType(0x7e0) end
	return res
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetTarget(s.reptg)
	e1:SetOperation(function(e) Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT+REASON_REPLACE) end)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_MZONE) and c:IsAbleToExtra() and not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
		return true
	else return false end
end
