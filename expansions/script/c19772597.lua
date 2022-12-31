--Tattica Aoj - Riti della Resurrezione
--Script by XGlitchy30
function c19772597.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772597,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c19772597.sptg)
	e1:SetOperation(c19772597.spop)
	c:RegisterEffect(e1)
	if not c19772597.global_check then
		c19772597.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c19772597.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
--global check
function c19772597.callback(c)
	local tp=c:GetPreviousControler()
	if c:IsSetCard(0x197) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControler(tp) then
		c:RegisterFlagEffect(19772597,RESET_EVENT+0x1fe0000,0,1)
	end
end
function c19772597.checkop(e,tp,eg,ep,ev,re,r,rp)
	eg:ForEach(c19772597.callback)
end
--filters
function c19772597.spfilter(c,tp,e)
	return c:GetFlagEffect(19772597)~=0 and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19772597.rmfilter(c)
	return c:GetLevel()==4 and c:IsSetCard(0x197) and c:IsAbleToRemove()
end
--Activate
function c19772597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c19772597.spfilter,1,nil,tp,e) and Duel.IsExistingTarget(c19772597.rmfilter,tp,LOCATION_GRAVE,0,4,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tc=nil
	if eg:GetCount()==1 then
		tc=eg:GetFirst()
	elseif eg:GetCount()>1 then
		local sp=eg:Filter(c19772597.spfilter,nil,tp,e)
		if sp:GetCount()<=0 then return end
		tc=sp:Select(tp,1,1,nil):GetFirst()
	else
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c19772597.rmfilter,tp,LOCATION_GRAVE,0,3,3,tc)
	tc:CreateEffectRelation(e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(c19772597.chlimit)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function c19772597.chlimit(e,ep,tp)
	return tp==ep
end
function c19772597.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=eg:GetFirst()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end