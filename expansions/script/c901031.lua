--Alza-Rango-Magico Forza Preziosa Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.descon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.costfilter(c,e,tp)
	local exc=(e:GetHandler():IsLocation(LOCATION_HAND) and e:IsHasType(EFFECT_TYPE_ACTIVATE)) and e:GetHandler() or nil
	return c:IsCode(901019) and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,exc)
end
function s.fselect(g,e,tp)
	local exg=g:Clone()
	if e:GetHandler():IsLocation(LOCATION_HAND) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		exg:AddCard(e:GetHandler())
	end
	return Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_HAND+LOCATION_GRAVE,0,#g,exg)
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local opt=Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp)
	if opt and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local rg=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=rg:SelectSubGroup(tp,s.fselect,false,1,rg:GetCount(),e,tp)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		aux.UseExtraReleaseCount(sg,tp)
		local ct=Duel.Release(sg,REASON_COST)
		e:SetLabel(ct)
	else
		e:SetLabel(0)
	end
end
function s.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x48)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetCode())
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
function s.filter2(c,e,tp,mc,rk,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x48) and c:IsRank(rk) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or not tc:IsType(TYPE_XYZ) or not tc:IsAttribute(ATTRIBUTE_DARK) or not tc:IsSetCard(0x48) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		local ct=e:GetLabel()
		if ct>0 and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,nil) then
			Duel.BreakEffect()
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanOverlay),tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,ct,nil)
			if #g>0 then
				Duel.Overlay(sc,g)
			end
		end
	end
end

function s.descfilter(c,tp)
	local no=c.xyz_number
	return c:IsType(TYPE_XYZ) and no and no>=200 and no<=213 and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:IsExists(s.descfilter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,eg) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local exg=eg:GetFirst():IsType(TYPE_XYZ) and eg or nil
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exg)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA):Filter(Card.IsFaceup,nil)
		for oc in aux.Next(og) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(oc:GetLocation())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			oc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			oc:RegisterEffect(e2)
		end
	end
end