function c111765876.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c111765876.lcheck)
	c:EnableReviveLimit()
	--scrapdragon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765876,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c111765876.target)
	e1:SetOperation(c111765876.activate)
	c:RegisterEffect(e1)
	--float
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(111765876,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,111765876)
	e2:SetCondition(c111765876.thcon)
	e2:SetTarget(c111765876.thtg)
	e2:SetOperation(c111765876.thop)
	c:RegisterEffect(e2)
end
	--link summon
function c111765876.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0x736)
end
	--scrapdragon
function c111765876.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x736)
end
function c111765876.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c111765876.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,c111765876.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
function c111765876.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	local sc=e:GetLabelObject()
	if sg:GetCount()~=2 or sc:IsFacedown() or not sc:IsSetCard(0x736) or sc:IsControler(1-tp) then return end
	Duel.Destroy(sg,REASON_EFFECT)
end
--float
function c111765876.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function c111765876.spfilter(c,e,tp)
	return c:IsSetCard(0x736) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_LINK)
end
function c111765876.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c111765876.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c111765876.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end