--Terradicazione Infernocrociato
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.matfilter,2,3,s.lcheck)
	c:EnableReviveLimit()
	--Cannot be Link Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Send to GY, Damage
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.LinkSummonedCond)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--SS
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT)
end
function s.include(c)
	return c:IsLinkType(TYPE_PANDEMONIUM) and c:IsLinkRace(RACE_DINOSAUR)
end
function s.lcheck(g,lc)
	return g:IsExists(s.include,1,nil)
end

function s.cfilter0(c,g)
	return c:IsMonster() and c:IsRace(RACE_DINOSAUR) and g:IsContains(c)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(s.cfilter0,1,nil,lg)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,100,REASON_EFFECT)
end

function s.filter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x9b5) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,999,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			local sg=Duel.GetOperatedGroup()
			local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			if ct>0 then
				Duel.Damage(1-tp,ct*300,REASON_EFFECT)
			end
		end
	end
end

function s.cfilter(c,lg,tp)
	return lg:IsContains(c) and c:IsControler(tp) and c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x9b5) and c:HasLevel() and c:IsLevelBelow(4)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.cfilter,1,nil,lg,tp)
end
function s.tgf(c,e,tp,eg,lg)
	return s.cfilter(c,lg,tp) and eg:IsContains(c) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA,0,1,c,e,tp,{c:GetCode()})
end
function s.spfilter1(c,e,tp,codes)
	return c:IsMonster() and c:IsCode(table.unpack(codes)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsInExtra() and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsInExtra() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and eg:IsContains(chkc) and s.cfilter(chkc,lg,tp) end
	if chk==0 then return zone~=0 and Duel.IsExistingTarget(s.tgf,tp,LOCATION_MZONE,0,1,nil,e,tp,eg,lg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgf,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg,lg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,{tc:GetCode()})
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end