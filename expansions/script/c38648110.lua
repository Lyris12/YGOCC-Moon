--Alvor, Vero Predicatore tra gli Elyriani
function c38648110.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),1,1)
	c:EnableReviveLimit()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c38648110.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCondition(c38648110.tgcon)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	local mcheck=Effect.CreateEffect(c)
	mcheck:SetType(EFFECT_TYPE_SINGLE)
	mcheck:SetCode(EFFECT_MATERIAL_CHECK)
	mcheck:SetValue(c38648110.valcheck)
	mcheck:SetLabelObject(e1)
	c:RegisterEffect(mcheck)
	local mclone=mcheck:Clone()
	mclone:SetLabelObject(e1x)
	c:RegisterEffect(mclone)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38648110,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c38648110.spcon)
	e2:SetTarget(c38648110.sptg)
	e2:SetOperation(c38648110.spop)
	c:RegisterEffect(e2)
end
--filters
function c38648110.spcheck(c,g)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and g:IsContains(c)
end
function c38648110.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:GetLevel()<=4 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
--protection
function c38648110.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,38648102) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c38648110.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
--spsummon
function c38648110.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(c38648110.spcheck,1,nil,lg)
end
function c38648110.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c38648110.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c38648110.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c38648110.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end