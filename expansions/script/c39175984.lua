--Bee Blade
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--SS
	local e1,e1x,e1y=c:SummonedTrigger(false,true,true,true,0,CATEGORY_SPECIAL_SUMMON,false,{1,0},nil,nil,s.sptg,s.spop)
	--Change Position
	local e2=c:Quick(false,1,CATEGORY_POSITION,EFFECT_FLAG_CARD_TARGET,nil,nil,{1,2},nil,aux.DiscardCost,aux.Target(s.posfilter,LOCATION_MZONE,0,1,1,true,s.poschk,s.posinfo),s.posop)
	--Gain ATK
	local e3=c:PositionFieldTrigger(nil,true,2,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,0,nil,nil,s.boostcon,nil,nil,s.boostop,true)
end

function s.filter(c,e,tp,pos)
	return c:IsMonster() and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN-pos)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetPosition())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c:GetPosition())
	if #g>0 then
		local available_pos=0
		for i=0,3 do
			if i~=1 and c:GetPosition()~=2^i and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,2^i) then
				available_pos=available_pos|2^i
			end
		end
		local pos=Duel.SelectPosition(tp,g:GetFirst(),available_pos)
		Duel.SpecialSummon(g,0,tp,tp,false,false,pos)
	end
end

function s.posfilter(c,e)
	local g=e:GetHandler():GlitchyGetColumnGroup(1,1)
	return c:IsMonster() and c:IsCanChangePosition() and g:IsContains(c)
end
function s.poschk(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsCanChangePosition()
end
function s.posinfo(g,e,tp,eg,ep,ev,re,r,rp)
	local sg=g:Clone()
	sg:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) and Duel.PositionChange(c)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.PositionChange(tc)
		end
	end
end

function s.cf(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.boostcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cf,1,nil)
end
function s.boostop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cf,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	for tc in aux.Next(g) do
		tc:UpdateATK(700,RESET_PHASE+PHASE_END,e:GetHandler())
		tc:UpdateDEF(700,RESET_PHASE+PHASE_END,e:GetHandler())
	end
end