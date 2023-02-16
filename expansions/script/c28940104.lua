--Hollohom Possession Art
local ref,id=GetID()
xpcall(function() require("expansions/script/Hollohom") end,function() require("script/Hollohom") end)
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2,id)
	e2:SetCost(ref.eqcost)
	e2:SetTarget(ref.eqtg)
	e2:SetOperation(ref.eqop)
	c:RegisterEffect(e2)
	--Recurr
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(2,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(ref.thtg)
	e3:SetOperation(ref.thop)
	c:RegisterEffect(e3)
end

--Activate
function ref.ssfilter(c,e,tp) return Hollohom.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	else e:SetCategory(0) end
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) or not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end

--Equip
function ref.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function ref.tgfilter(c)
	if c:GetMaterialCount()<2 then return false end
	local mg=c:GetMaterial():Filter(Card.IsLevelAbove,nil,1)
	return mg:GetClassCount(Card.GetLevel)==mg:GetCount()
end
function ref.eqfilter(c,tp) return Hollohom.Is(c) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) end
function ref.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(ref.tgfilter,1,nil)
		and Duel.IsExistingMatchingCard(ref.eqfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function ref.subfilter(g)
	return g:IsExists(ref.tgfilter,1,nil) and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)
end
function ref.eqop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(ref.tgfilter,nil)
	local g2=Duel.GetMatchingGroup(ref.eqfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and #g2>0 then
		g:Merge(g2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg=g:SelectSubGroup(tp,ref.subfilter,false,2,2)
		local ec=sg:Filter(Card.IsLocation,nil,LOCATION_DECK):GetFirst()
		local tc=sg:Filter(ref.tgfilter,nil):GetFirst()
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Equip(tp,ec,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(ref.eqlimit)
		ec:RegisterEffect(e1)
	end
end
function ref.eqlimit(e,c)
	return e:GetLabelObject()==c
end

--Recurr
function ref.thfilter(c) return Hollohom.Is(c) and c:IsAbleToHand() end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(ref.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,ref.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function ref.thop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
