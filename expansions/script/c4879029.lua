--Guscio Decadente
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--search
	c:SummonedTrigger(false,true,true,false,0,CATEGORIES_SEARCH,true,true,
		nil,
		aux.LabelCost,
		s.target,
		s.operation
	)
	--SS
	c:SentToGYTrigger(false,1,CATEGORY_SPECIAL_SUMMON,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,true,
		s.spcon,
		nil,
		aux.Target(s.spfilter,LOCATION_GRAVE,0,1,1,nil,s.spcheck,CATEGORY_SPECIAL_SUMMON),
		aux.SSOperationMod(SPSUM_MOD_REDIRECT,SUBJECT_IT,nil,nil,nil,nil,nil,{LOCATION_REMOVED,aux.Stringid(id,2)})
	)
end
function s.cfilter(c,tp)
	if not (c:IsMonster() and c:HasLevel() and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost()) then
		return false
	end
	local codes={}
	if c:IsAttribute(ATTRIBUTE_EARTH) then
		table.insert(codes,CARD_FOSSIL_FUSION)
	end
	if c:IsAttribute(ATTRIBUTE_DARK) then
		table.insert(codes,35705817)
	end
	return #codes>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c,codes)
end
function s.thfilter(c,codes)
	return c:IsCode(table.unpack(codes)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local lab1=e:GetLabel()
		if lab1~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local codes={}
		if tc:IsAttribute(ATTRIBUTE_EARTH) then
			table.insert(codes,CARD_FOSSIL_FUSION)
		end
		if tc:IsAttribute(ATTRIBUTE_DARK) then
			table.insert(codes,35705817)
		end
		local lab1=e:GetLabel()
		e:SetLabel(lab1,table.unpack(codes))
		Duel.SendtoGrave(g,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local _,code1,code2=e:GetLabel()
	local codes={code1}
	if code2 then
		table.insert(codes,code2)
	end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,codes)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(e,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end