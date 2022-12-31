--Codice Amministrale - Spada Laodicea della Rabbia "Ikari"
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,PLAYER_ALL,aux.FilterBoolFunction(Card.IsSetCard,0xd7c))
	--Atk Change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--attack all
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(s.cond)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--cannot be evicted from the apartment
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.cond)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
	--shuffle
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:HOPT()
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsInMainSequence,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil)*100
end

function s.cond(e)
	local eqc=e:GetHandler():GetEquipTarget()
	return eqc and eqc:IsCode(19782404)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	if chk==0 then
		return (r&REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER) and rp==1-tp and eg:IsContains(eqc)
		and eqc:GetDestination()&(LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA)>0
	end
	return true
end
function s.repval(e,c)
	local eqc=e:GetHandler():GetEquipTarget()
	return eqc and c==eqc
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():GetPreviousSequence()<5 and re:IsHasType(0x7e0)
		and re:GetHandler():IsSetCard(0xd7c)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if chk==0 then
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,tc,0,tp,tp,false,false,POS_FACEUP)
	end
end