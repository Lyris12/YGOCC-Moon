--Sunhewns' Entrance Ceremony
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Retrieve
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(ref.retcost)
	e2:SetTarget(ref.rettg)
	e2:SetOperation(ref.retop)
	c:RegisterEffect(e2)
end

--Activate
function ref.ssfilter(c,e,tp) return Sunhew.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.thfilter(c,tp)
	return Sunhew.Is(c) and c:IsType(TYPE_DRIVE) and c:IsAbleToHand() and c:IsCanEngage(tp)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+2
	end
	if opt==0 or opt==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if opt==0 or opt==2 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
	e:SetLabel(opt)
end
function ref.actop(e,tp)
	local opt=e:GetLabel()
	if opt==0 or opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then Duel.SearchAndEngage(g:GetFirst(),e,tp,true) end
	end
	if (opt==0 or opt==2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end

--Retrieve
function ref.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=Duel.GetEngagedCard(tp)
	if chk==0 then return ec~=nil and ec:IsCanUpdateEnergy(-3,tp,REASON_EFFECT) end
	ec:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
end
function ref.rettg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
function ref.retop(e,tp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
