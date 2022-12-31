--Mago Pandemoniografo
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--PANDEMONIUM EFFECTS
	--spsummon
	local pand1=Effect.CreateEffect(c)
	pand1:SetDescription(aux.Stringid(id,0))
	pand1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	pand1:SetType(EFFECT_TYPE_QUICK_O)
	pand1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	pand1:SetCode(EVENT_FREE_CHAIN)
	pand1:SetRange(LOCATION_SZONE)
	pand1:SetCountLimit(1,id)
	pand1:SetCondition(aux.PandActCheck)
	pand1:SetTarget(cid.pandtg)
	pand1:SetOperation(cid.pandop)
	c:RegisterEffect(pand1)
	aux.EnablePandemoniumAttribute(c,pand1)
	--MONSTER EFFECTS
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+100)
	e1:SetCondition(cid.spcon)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--quick act
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+200)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(cid.quickact)
	c:RegisterEffect(e2)
end
--filters
function cid.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xcf80)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:GetSequence()<5)
end
function cid.seqfix(c,ft)
	return ft>0 or c:GetSequence()<5
end
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf80) and not c:IsCode(id)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
--spsummon
function cid.pandtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.pandop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xcf80,0x21,2500,2000,7,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			e:GetHandler():AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
--special summon rule
function cid.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	return g:GetCount()>0 and ft>-1 and g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>-ft
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	local sg=nil
	if ft<=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local zg=g:Filter(cid.seqfix,nil,ft)
		sg=zg:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sg=g:Select(tp,1,1,nil)
	end
	Duel.Destroy(sg,REASON_COST)
end
--quickact
function cid.quickact(e,c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsSetCard(0xcf80)
end