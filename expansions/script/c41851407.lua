--created by Walrus, coded by Lyris, art from Shadowverse's "Ghastly Assault"
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	c:SetUniqueOnField(1,0,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(function(e) e:SetLabel(100) return true end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp,mg)
	return c:IsSetCard(0x106) and c:GetType()&0x81==0x81 and not c:IsPublic()
		and mg:CheckSubGroup(s.check,1,99,tp,c:GetLevel())
end
function s.check(g,tp,lv)
	return g:CheckWithSumEqual(Card.GetLevel,lv,#g,#g) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g
end
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x106) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp,g)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp,g):GetFirst()
	e:SetLabel(tc:GetLevel())
	Duel.ConfirmCards(1-tp,g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	for tc in aux.Next(Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp):SelectSubGroup(tp,s.check,false,1,99,tp,e:GetLabel())) do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			aux.CannotBeEDMaterial(tc,s.limit(1-tp),LOCATION_MZONE,false,RESET_EVENT+RESETS_STANDARD)
		end
	end
	Duel.SpecialSummonComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x106))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.limit(p)
	return  function(c)
				return c:IsControler(p)
			end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsControler(tp) and rc==Duel.GetAttacker()
		and rc:IsFaceup() and rc:IsSetCard(0x106) and rc:GetType()&0x81==0x81
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	if not c:IsRelateToEffect(e) or rc:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	rc:RegisterEffect(e2)
end
