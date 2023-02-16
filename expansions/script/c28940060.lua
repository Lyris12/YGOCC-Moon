--Elemerge Cadet, Launa
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	--Transform
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1163)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(ref.transcon)
	e1:SetOperation(ref.transop)
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
	--Fusion
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(ref.fustg)
	e3:SetOperation(ref.fusop)
	c:RegisterEffect(e3)
end

--Transform
function ref.transfilter(c,e,tp)
	return Elemerge.Is(c) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and (Duel.IsExistingMatchingCard(Card.IsAttribute,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetAttribute())
		or Duel.IsExistingMatchingCard(Card.IsRace,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetRace()))
end
function ref.transcon(e,c,og)
	if c==nil then return true end
	local g=nil
	local tp=e:GetHandlerPlayer()
	if og then
		g=og:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	else
		g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	end
	return g:IsExists(ref.transfilter,1,nil,e,tp)
end
function ref.transop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local tg=nil
	if og then
		tg=og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):Filter(ref.transfilter,nil,e,tp)
	else
		tg=Duel.GetMatchingGroup(ref.transfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if not sg or #sg<1 then sg:Merge(tg:SelectSubGroup(tp,aux.TRUE,true,1,1)) end
	if #sg<1 then return end
	sg:GetFirst():SetMaterial(Group.FromCards(e:GetHandler()))
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

--Search
function ref.thfilter(c)
	return Elemerge.Is(c) and c:IsAbleToHand() and not c:IsCode(id)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end

--Fusion
function ref.fusfilter(c,e,tp,mg,gc)
	return c:IsType(TYPE_FUSION) and Elemerge.Is(c) and c:CheckFusionMaterial(mg,gc,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function ref.matfilter(c) return c:IsFaceup() and c:IsAbleToDeck() end
function ref.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		e:GetHandler():AssumeProperty(ASSUME_RACE,RACE_ALL)
		return Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	c:AssumeProperty(ASSUME_RACE,RACE_ALL)
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fg=Duel.SelectMatchingCard(tp,ref.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c)
	if #fg>0 then
		local fc=fg:GetFirst()
		local mats=Duel.SelectFusionMaterial(tp,fc,mg,c,tp)
		fc:SetMaterial(mats)
		Duel.SendtoGrave(mats,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
