--MMS - Agguatante
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:SSProc(0,nil,LOCATION_HAND,true,s.spcon)
	--ss
	c:SummonedTrigger(false,false,true,false,1,CATEGORY_SPECIAL_SUMMON,true,true,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--draw
	c:SummonedFieldTrigger(s.cfilter,false,false,true,false,2,CATEGORY_DRAW,true,LOCATION_MZONE,true,
		nil,
		nil,
		aux.DrawTarget(1,PLAYER_ALL),
		aux.DrawOperation(1,1,PLAYER_ALL)
	)
end
function s.spcon(e,c,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end

function s.spfilter(c)
	if c:IsLocation(LOCATION_HAND) then
		return not c:IsPublic() or c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_DEFENSE)
	elseif c:IsLocation(LOCATION_DECK) then
		return c:GetSequence()~=0 or not c:IsFaceup() or c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.spfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #g>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Group(s.spfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local sg=g:Select(1-tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummonMod(e,sg,0,1-tp,1-tp,false,false,POS_FACEUP_DEFENSE,nil,{SPSUM_MOD_NEGATE},{SPSUM_MOD_CHANGE_ATKDEF,0})
		end
	end
end

function s.cfilter(c,e,tp)
	return c:IsControler(1-tp)
end