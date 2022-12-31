--Steinitz's King
--Script by XGlitchy30
function c25386880.initial_effect(c)
	--fusion summon
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x63d0),5,true)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c25386880.atlimit)
	c:RegisterEffect(e2)
	--battle immunity
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(c25386880.pbattle)
	c:RegisterEffect(e3)
	--spsummon and equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25386880,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c25386880.spcon)
	e4:SetTarget(c25386880.sptg)
	e4:SetOperation(c25386880.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e6)
end
c25386880.material_setcode=0x63d0
--filters
function c25386880.spfilter(c,e,tp)
	return c:IsSetCard(0x63d0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(c25386880.eqfilter,tp,LOCATION_GRAVE,0,1,c,tp)
end
function c25386880.eqfilter(c,tp)
	return c:IsSetCard(0x63d0) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
--values
function c25386880.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x63d0) and c~=e:GetHandler()
end
function c25386880.pbattle(e,c)
	local ctr=e:GetHandler():GetColumnGroup()
	return not ctr:IsContains(c)
end
function c25386880.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--spsummon
function c25386880.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c25386880.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25386880.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c25386880.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c25386880.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function c25386880.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sp=sg:FilterSelect(tp,c25386880.spfilter,1,1,nil,e,tp)
		if sp:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local eq=sg:FilterSelect(tp,c25386880.eqfilter,1,1,sp:GetFirst(),tp)
			if eq:GetCount()>0 then
				Duel.SpecialSummon(sp:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
				Duel.Equip(tp,eq:GetFirst(),sp:GetFirst())
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				e1:SetValue(c25386880.eqlimit)
				e1:SetLabelObject(sp:GetFirst())
				eq:GetFirst():RegisterEffect(e1)
			end
		end
	end
end
