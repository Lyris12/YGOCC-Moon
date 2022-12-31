--Settimosigillo Invocazione
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--activate
	c:Activate(0,CATEGORIES_SEARCH,nil,nil,nil,
		nil,
		nil,
		aux.SearchTarget(s.thfilter),
		s.thop
	)
	--energy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_ENGAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.encon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.entg)
	e2:SetOperation(s.enop)
	c:RegisterEffect(e2)
end
function s.thfilter(c,e,tp)
	return c:IsMonster()
		and (c:IsSetCard(0x7ec) or (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil) and c:IsSetCard(0x7eb)))
end
function s.thfilterop(c,set)
	return c:IsMonster() and c:IsSetCard(set) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Group(s.thfilterop,tp,LOCATION_DECK,0,nil,0x7ec)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil) then
		local g2=Duel.Group(s.thfilterop,tp,LOCATION_DECK,0,g1,0x7eb)
		if #g2>0 then
			g1:Merge(g2)
		end
	end
	if #g1>0 then
		Duel.HintMessage(tp,HINTMSG_ATOHAND)
		local sg=g1:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

function s.cfilter(c,rp,tp)
	return c:IsMonster() and c:IsSetCard(0x7eb) and rp==tp
end
function s.encon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,rp,tp) and
			Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil)
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if not en then return false end
		for i=3,-3,-1 do
			if i~=0 and en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if not en then return end
	local nums={}
	for i=3,-3,-1 do
		if i~=0 and en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
			table.insert(nums,i)
		end
	end
	if #nums==0 then return end
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	en:UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler())
end