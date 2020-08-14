local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(aux.exccon)
	e4:SetCost(cid.indcost)
	e4:SetTarget(cid.tg)
	e4:SetOperation(cid.op)
	c:RegisterEffect(e4)
end
function cid.filter(c,e,tp,m,ft)
	if not c:IsSetCard(0x617) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99,c)
	else
		return ft>-1 and mg:IsExists(cid.mfilterf,1,nil,tp,mg,c)
	end
end
function cid.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetLevel,rc:GetLevel(),0,99,rc)
	else return false end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg,ft)
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil)
		end
		local mat=nil
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,99,tc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:FilterSelect(tp,cid.mfilterf,1,1,nil,tp,mg,tc)
			Duel.SetSelectedCard(mat)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat2=mg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),0,99,tc)
			mat:Merge(mat2)
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function cid.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cid.tgf(c)
	return c:IsFaceup() and c:IsSetCard(0x617)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.tgf(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.tgf,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.tgf,tp,LOCATION_MZONE,0,1,1,nil)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
--Lunarium Resolution
function cid.ope(e,tp,eg)
	if e:GetHandler():IsStatus(STATUS_DISABLED) then return end
	op=0
	local lv=0
	tmp=eg:GetFirst()
	for i=1,#eg do lv=lv+tmp:GetLevel() tmp=eg:GetNext() end
	if eg:CheckWithSumEqual(Card.GetLevel,6,2,2)
	and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,6)
	then op=op+1 end
	if Duel.GetMatchingGroup(function(c,g)
		return not g:IsContains(c)
	end,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,eg):CheckWithSumEqual(Card.GetLevel,9-lv,1,99)
	and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,9)
	then op=op+2 end
	if op==0 then return end
	if bit.band(op,1)>0 and bit.band(op,2)>0 then
		tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if tc:GetLevel()==9 then
			c=Duel.GetMatchingGroup(function(c,g)
				return not g:IsContains(c)
			end,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,eg):SelectWithSumEqual(tp,Card.GetLevel,9-lv,1,99):GetFirst()
			eg:AddCard(c)
		end
	elseif bit.band(op,1)>0 then
		tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,6):GetFirst()
	elseif bit.band(op,2)>0 then
		tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,9):GetFirst()
		c=Duel.GetMatchingGroup(function(c,g)
			return not g:IsContains(c)
		end,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,eg):SelectWithSumEqual(tp,Card.GetLevel,9-lv,1,99):GetFirst()
		eg:AddCard(c)
	end
	tc:SetMaterial(eg)
	Duel.ReleaseRitualMaterial(eg)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	tc:CompleteProcedure()
end
