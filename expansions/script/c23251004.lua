--Moon Over the Desert
local id,cod=23251004,c23251004
function cod.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
	if not cod.global_check then
		cod.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(cod.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function cod.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local ct=0
	while tc do
		if tc:GetFlagEffect(id)==0 and tc:IsSetCard(0xd3e) then
			ct=ct+1
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
			e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1,ct)
		end
		tc=eg:GetNext()
	end
end
function cod.filter1(c,e,tp)
	return c:GetSummonPlayer()==tp and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
		and c:GetFlagEffect(id)>0 and Duel.IsExistingTarget(cod.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c:GetAttack(),c:GetCode())
end
function cod.filter2(c,e,tp,atk,code)
	return c:IsAttackBelow(atk) and c:GetCode()~=code and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTSMG_TARGET)
	Duel.SelectTarget(tp,cod.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(cod.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp,tc:GetAttack(),tc:GetCode())
		if g:GetCount()<0 then return end
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
