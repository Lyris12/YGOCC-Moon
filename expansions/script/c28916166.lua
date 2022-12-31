--Coded by Kinny~
local ref=_G['c'..28916166]
local id=28916166
function ref.initial_effect(c)
	--Effect 0
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(ref.cost)
	e0:SetTarget(ref.target0)
	e0:SetOperation(ref.operation0)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,ref.chainfilter)
end
function ref.RecoverV(c)
	return c:IsSetCard(1856) and c:IsAbleToHand()
end
function ref.SSVMon(c,e,tp)
	return c:IsSetCard(1856) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

--Check
function ref.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function ref.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(ref.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function ref.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function ref.target0(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ref.RecoverV(chkc) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(ref.RecoverV,tp,LOCATION_GRAVE,0,1,nil) or Duel.IsExistingMatchingCard(ref.SSVMon,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	local res1=Duel.IsExistingTarget(ref.RecoverV,tp,LOCATION_GRAVE,0,1,nil)
	local res2=Duel.IsExistingMatchingCard(ref.SSVMon,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local opt=1
	e:SetProperty(e:GetProperty()|EFFECT_FLAG_CARD_TARGET)
	if res2 then
		opt = 2
	end
	if (res1 and res2) then
		opt = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	end
	e:SetLabel(opt)
	local cat=0
	if opt==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g0 = Duel.SelectTarget(tp,ref.RecoverV,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g0,#g0,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
		cat=cat|(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	elseif opt==1 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g0 = Duel.SelectTarget(tp,ref.RecoverV,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g0,g0:GetFirst():GetControler(),g0:GetCount(),g0:GetFirst():GetLocation())
		cat=cat|CATEGORY_TOHAND
	elseif opt==2 then
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
		cat=cat|CATEGORY_SPECIAL_SUMMON
	end
	e:SetCategory(cat)
end
function ref.operation0(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if (opt==0 or opt==1) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,tp,REASON_EFFECT)
		end
	end
	if (opt==0 or opt==2) then
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(ref.SSVMon),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
		end
	end
end
