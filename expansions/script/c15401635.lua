--Ombra del Sovrano Pulstar
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use each effect of "Shadow of the Pulstar Ruler" once per turn.

① If exactly 1 Warrior monster you control would be destroyed by battle or by an opponent's card effect, you can destroy this card in your hand instead.
② If exactly 1 "Pulstar" monster you control would be destroyed by battle or by an opponent's card effect, you can banish this card from your GY instead.
③ If you control another face-up "Pulstar" monster with a higher Level: You can Tribute this card; Special Summon 1 Warrior monster from your Deck with the same Attribute, Level, original ATK and original DEF as 1 face-up "Pulstar" monster you control.
]]

function s.initial_effect(c)
	--replace
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg2)
	e2:SetValue(s.repval2)
	e2:SetOperation(s.repop2)
	c:RegisterEffect(e2)
	--ss
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
		and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp) and not eg:IsExists(s.repfilter,2,c,tp) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

function s.repfilter2(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x792)
		and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp))
end
function s.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp) and not eg:IsExists(s.repfilter,2,c,tp) and c:IsAbleToRemove() end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval2(e,c)
	return s.repfilter2(c,e:GetHandlerPlayer())
end
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

function s.cf(c,lv)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x792) and c:GetLevel()>lv
end
function s.spcon(e,tp)
	return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler():GetLevel())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.copyfilter(c,attr,lv,atk,def)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x792) and c:IsAttribute(attr) and c:IsLevel(lv) and c:GetBaseAttack()==atk and c:GetBaseDefense()==def
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_MZONE,0,1,nil,c:GetAttribute(),c:GetLevel(),c:GetBaseAttack(),c:GetBaseDefense())	
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local check = (e:GetLabel()==1) and Duel.GetMZoneCount(tp,c)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local exc = (e:GetLabel()==1) and c or nil
		e:SetLabel(0)
		return check and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,exc,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end