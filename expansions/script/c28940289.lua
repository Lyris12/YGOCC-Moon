--Ellien, Sunhewn Pupil
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	--NSummon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetTarget(ref.nstg)
	e1:SetOperation(ref.nsop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Material
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.xyztg)
	e2:SetOperation(ref.xyzop)
	c:RegisterEffect(e2)
end

--Summon
function ref.nsfilter(c) return c:IsLevel(1,6) and c:IsSummonable(true,nil) end
function ref.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function ref.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

--Material
function ref.xyzfilter(c) return c:IsType(TYPE_XYZ) and c:IsFaceup() end
function ref.xyztg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	local ec=Duel.GetEngagedCard(tp)
	if chk==0 then return ec~=nil and ec:IsCanUpdateEnergy(1,tp,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(ref.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_GRAVE,0,1,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function ref.xyzgfilter(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2
		and g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2
end
function ref.xyzop(e,tp) local c=e:GetHandler()
	local ec=Duel.GetEngagedCard(tp)
	if ec~=nil and ec:IsCanUpdateEnergy(1,tp,REASON_EFFECT) then
		ec:UpdateEnergy(1,tp,REASON_COST,true,c)
		local g=Duel.GetMatchingGroup(Card.IsCanOverlay,tp,LOCATION_GRAVE,0,nil)
		g:Merge(Duel.GetMatchingGroup(ref.xyzfilter,tp,LOCATION_MZONE,0,nil))
		if g:CheckSubGroup(ref.xyzgfilter,2,2) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sg=g:SelectSubGroup(tp,ref.xyzgfilter,false,2,2)
			local xc=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
			sg:RemoveCard(xc)
			Duel.Overlay(xc,sg)
		end
	end
end
