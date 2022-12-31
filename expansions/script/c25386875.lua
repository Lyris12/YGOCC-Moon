--Steinitz's Tactics
--Script by XGlitchy30
function c25386875.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25386875,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,25386875)
	e1:SetTarget(c25386875.eqtg)
	e1:SetOperation(c25386875.eqop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25386875,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21386875)
	e2:SetTarget(c25386875.sptg)
	e2:SetOperation(c25386875.spop)
	c:RegisterEffect(e2)
	--zone movement
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25386875,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,22386875)
	e3:SetCondition(c25386875.zonecon)
	e3:SetTarget(c25386875.zonetg)
	e3:SetOperation(c25386875.zoneop)
	c:RegisterEffect(e3)
end
--filters
function c25386875.eqtarget(c)
	return c:IsFaceup() and c:IsSetCard(0x63d0)
end
function c25386875.eqcard(c,tp)
	return c:IsSetCard(0x63d0) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c25386875.sptarget1(c,tp,e,pl)
	local ec=c:GetEquipTarget()
	return c:IsSetCard(0x63d0) and ec and ec:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,pl,false,false)
end
function c25386875.sptarget2(c,tp,e,pl)
	local ec=c:GetEquipTarget()
	return c:IsSetCard(0x63d0) and ec and ec:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,pl,false,false)
end
function c25386875.sptarg_final(c,e,tp)
	local ec=c:GetEquipTarget()
	return c:IsSetCard(0x63d0) and ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--values
function c25386875.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--equip
function c25386875.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c25386875.eqtarget(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c25386875.eqtarget,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c25386875.eqcard,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c25386875.eqtarget,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c25386875.eqop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,c25386875.eqcard,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if ec then
		Duel.Equip(tp,ec,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c25386875.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
	end
end
--special summon
function c25386875.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c25386875.sptarg_final(chkc,e,tp) end
	if chk==0 then return (Duel.IsExistingTarget(c25386875.sptarget1,tp,LOCATION_SZONE,0,1,nil,tp,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		or (Duel.IsExistingTarget(c25386875.sptarget2,tp,0,LOCATION_SZONE,1,nil,1-tp,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c25386875.sptarg_final,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	if g:GetFirst():IsControler(tp) then
		e:SetLabel(0)
	else
		e:SetLabel(1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c25386875.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetLabel()==1 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if e:GetLabel()==0 and tc:IsControler(tp) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
--zone movement
function c25386875.zonecon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function c25386875.zonetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsSetCard(0x63d0) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x63d0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88392300,0))
	Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,1,1,nil,0x63d0)
end
function c25386875.zoneop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(tc,nseq)
end