--Necroblessing
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:GLString(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e1:SetGlitchyCategory(GLCATEGORY_SYNCHRO_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.filter(c,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and ((aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and ft>0 and c:IsAbleToExtra() and Duel.IsExistingMatchingCard(cid.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttack()))
		or (ft>1 and Duel.GetMatchingGroup(cid.mfilter,tp,LOCATION_GRAVE,0,nil,e,tp):CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,ft)))
end
function cid.synfilter(c,e,tp,atk)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE) and c:GetAttack()==atk
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function cid.mfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetMatchingGroup(cid.mfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	mg:KeepAlive()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	--
	local b0=(tc and tc:IsRelateToEffect(e) and (not tc:IsLocation(LOCATION_REMOVED) or tc:IsFaceup()))
	local b1=(aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and ft>0 and tc:IsAbleToExtra() and Duel.IsExistingMatchingCard(cid.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc:GetAttack()))
	local b2=(b0 and ft>1 and mg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,ft))
	--
	local op
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	if not op then return end
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,cid.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetAttack()):GetFirst()
		if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			if b0 then
				Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=mg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,ft)
		if #tg>0 then
			local sc=tg:GetFirst()
			local check=0
			while sc do
				if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
					check=check+1
				end
				sc=tg:GetNext()
			end
			Duel.SpecialSummonComplete()
			if check==#tg and tg:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				local tn=tg:FilterSelect(aux.NOT(Card.IsType),1,1,nil,TYPE_TUNER):GetFirst()
				if tn then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_ADD_TYPE)
					e1:SetValue(TYPE_TUNER)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tn:RegisterEffect(e1)
				end
			end
		end
	end
end