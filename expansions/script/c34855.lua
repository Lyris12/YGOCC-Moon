--Tribolazione Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local en=Duel.GetEngagedCard(tp)
		if not en then return false end
		for i=1,3 do
			if en:IsCanUpdateEnergy(-i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if not en then return end
	local nums={}
	for i=1,3 do
		if en:IsCanUpdateEnergy(-i,tp,REASON_EFFECT) then
			table.insert(nums,i)
		end
	end
	if #nums==0 then return end
	local n=Duel.AnnounceNumber(tp,table.unpack(nums))
	local _,diff=en:UpdateEnergy(-n,tp,REASON_EFFECT,true,e:GetHandler())
	if diff==-n and Duel.IsExistingMatchingCard(aux.Faceup(Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,34844) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end