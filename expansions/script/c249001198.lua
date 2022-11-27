--Overlay-Knight Dragun
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249001198.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18326736,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c249001198.spcon)
	e1:SetCost(c249001198.spcost)
	e1:SetTarget(c249001198.sptg)
	e1:SetOperation(c249001198.spop)
	c:RegisterEffect(e1)
	--cannot special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c249001198.splimitself)
	e2:SetLabelObject(c)
	Duel.RegisterEffect(e2,0)
	--rank
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(567)
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c249001198.rktg)
	e3:SetOperation(c249001198.rkop)
	c:RegisterEffect(e3)
	--update race/att
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(562)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c249001198.tg)
	e4:SetOperation(c249001198.op)
	c:RegisterEffect(e4)
end
function c249001198.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x231)
end
function c249001198.costfilter(c)
	return c:IsSetCard(0x231) and c:IsAbleToRemoveAsCost()
end
function c249001198.costfilter2(c,e)
	return c:IsSetCard(0x231) and not c:IsPublic()
end
function c249001198.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249001198.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249001198.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249001198.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249001198.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249001198.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249001198.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249001198.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001198.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249001198.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249001198.filter(c,e,tp,rk,mc,race,att)
	return (c:IsRank(rk) or c:IsRank(rk+1)) and e:GetHandler():IsCanBeXyzMaterial(c) and c:IsRace(race) and c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c249001198.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCardFilter(tp,TYPE_XYZ,OPCODE_ISTYPE,249001198,OPCODE_ISCODE,OPCODE_OR)
		if ac==249001198 then return end
		cc=Duel.CreateToken(tp,ac)
	until not banned_list_table[ac]
	Duel.SendtoDeck(cc,nil,SEQ_DECKTOP,REASON_RULE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(ac)
	e1:SetTarget(c249001198.splimit)
	Duel.RegisterEffect(e1,tp)
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e)
		or not Duel.IsExistingMatchingCard(c249001198.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank(),c,c:GetRace(),c:GetAttribute()) or not Duel.SelectYesNo(tp,2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249001198.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetRank(),c,c:GetRace(),c:GetAttribute())
	local sc=g:GetFirst()
	if sc then
		local mg=c:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(sc,Group.FromCards(c))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function c249001198.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (not se:GetHandler():IsSetCard(0x231)) and c:IsCode(e:GetLabel()) and c:IsLocation(LOCATION_EXTRA)
end
function c249001198.splimitself(e,c,sump,sumtype,sumpos,targetp,se)
	return c==e:GetLabelObject() and se and se:GetHandler()~=e:GetLabelObject() and c:IsLocation(LOCATION_EXTRA)
end
function c249001198.rkfilter(c)
	return c:GetOriginalLevel() > 0 and c:IsDiscardable()
end
function c249001198.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001198.rkfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c249001198.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local tc=Duel.SelectMatchingCard(tp,c249001198.rkfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		local rk=1
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)~=0 then
			local ct={}
			for i=1,math.ceil(tc:GetOriginalLevel() / 2),1 do
				table.insert(ct,i)
			end
		if #ct>=1 then
			rk=Duel.AnnounceNumber(tp,table.unpack(ct))
		end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_RANK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(rk)
			c:RegisterEffect(e1)
		end
	end
end
function c249001198.chfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function c249001198.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c249001198.chfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,c)
	local g2=c:GetOverlayGroup():Filter(c249001198.chfilter,nil)
	g:Merge(g2)
	if chk==0 then return g:GetCount()>0 end
end
function c249001198.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(c249001198.chfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,c)
		local g2=c:GetOverlayGroup():Filter(c249001198.chfilter,nil)
		g:Merge(g2)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SelectYesNo(tp,1319) then
			local att=tc:GetAttribute()
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetValue(att)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
		if Duel.SelectYesNo(tp,1321) then
			local race=tc:GetRace()
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_RACE)
			e3:SetValue(race)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e3)
		end
	end
end