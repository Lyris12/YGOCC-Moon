--Flaircaster Unison
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_AIRCASTER))
	e1:SetValue(s.evalue)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	--excavate
	local ex=aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_QUICK_O,0,ARCHE_FLAIRCASTER,e2,CATEGORY_SPECIAL_SUMMON)
	e2:SetLabelObject(ex)
	--equip
	aux.AddAircasterEquipEffect(c,2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.econ)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.evalue(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_AIRCASTER),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*300
end

function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.econ(e)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	return eqc and c:IsSpell(TYPE_EQUIP) and Duel.GetAttacker()==eqc
end
function s.damop(e,tp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end