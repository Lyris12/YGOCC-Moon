--Stellarius, Divine-Eye's Intervention
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(s.announcecost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	--Shuffle Summon, quick effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end
function s.filter22(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.filter3(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) and c:IsCode(997695)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
    local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and g:GetClassCount(Card.GetCode)>=3 and gg:GetClassCount(Card.GetCode)>=3 
			and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-3 then return end
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
	local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 and gg:GetClassCount(Card.GetCode)>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g3=g:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg1=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg2=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg3=gg:Select(tp,1,1,nil)
		g1:Merge(g2)
		g1:Merge(g3)
		g1:Merge(gg1)
		g1:Merge(gg2)
		g1:Merge(gg3)
		Duel.SendtoGrave(g1,REASON_EFFECT+REASON_FUSION)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g4=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if tc then
			tc:SetMaterial(g1)
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

function s.filter33(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) and c:IsCode(997730)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
    local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and g:GetClassCount(Card.GetCode)>=2 and gg:GetClassCount(Card.GetCode)>=2 
			and Duel.IsExistingMatchingCard(s.filter33,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-2 then return end
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
	local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 and gg:GetClassCount(Card.GetCode)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=g:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg1=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg2=gg:Select(tp,1,1,nil)
		g1:Merge(g2)
		g1:Merge(gg1)
		g1:Merge(gg2)
		Duel.SendtoGrave(g1,REASON_EFFECT+REASON_FUSION)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g4=Duel.SelectMatchingCard(tp,s.filter33,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if tc then
			tc:SetMaterial(g1)
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

function s.tdfilter(c,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION) and c:IsAbleToDeck()
	 and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
function s.spgyfilter(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(s.spgyfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),3)
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if ft<=0 or #g==0 then return end
		if #g>0 and ft>=1 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=g:Select(tp,1,1,nil,e,tp)
		g:Remove(Card.IsAttribute,nil,g1:GetFirst():GetAttribute())
		if #g>0 and ft>1 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=g:Select(tp,1,1,nil,e,tp)
			g:Remove(Card.IsAttribute,nil,g2:GetFirst():GetAttribute())
			g1:Merge(g2)
			if #g>0 and ft>2 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
				g2=g:Select(tp,1,1,nil,e,tp)
				g1:Merge(g2)
			end
		end
		local tc=g1:GetFirst()
		for tc in aux.Next(g1) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
			Duel.SpecialSummonComplete()
		end		
	end
end