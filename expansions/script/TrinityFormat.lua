--Trinity Format Mode
--Ejeffers & Lyris
function sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsType(TYPE_EFFECT) and lim[sump]<=0
end
function resetop(e,tp,eg,ep,ev,re,r,rp)
	lim[0]=3
	lim[1]=3
	lim[2]=0
	lim[3]=0
end
function sumexcess(c,tp,lc)
	return c:IsType(TYPE_EFFECT+TYPE_DUAL) and not c:IsSummonType(SUMMON_TYPE_DUAL) and c:GetSummonPlayer()==tp and c:GetSummonLocation()==lc
end
function checkop(e,tp,eg,ep,ev,re,r,rp)
	local ps=0
    for tc in aux.Next(eg) do
		local p=tc:GetSummonPlayer()
		ps=ps|1<<p
		if lim[p]==0 and (tc:IsSummonType(SUMMON_TYPE_DUAL) or tc:IsCode(45467446,86489182)) then lim[p+2]=lim[p+2]-1 end
        if tc:IsType(TYPE_EFFECT+TYPE_DUAL) or tc:IsFacedown() then lim[p]=lim[p]-1 end
	end
	for p=0,1 do
		if ps&1<<p~=0 and lim[p]<lim[p+2] then
			for i=0,6 do
				local lc=1<<i
				if #eg>0 and Duel.GetCurrentChain()>0 then lc=16 end
				if lc==1 then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
					local g=eg:FilterSelect(p,sumexcess,-lim[p]+lim[p+2],-lim[p]+lim[p+2],nil,p,lc)
					Duel.NegateSummon(g)
					Duel.DisableShuffleCheck()
					for nc in aux.Next(g) do Duel.SendtoDeck(nc,p,nc:GetPreviousSequence(),REASON_RULE+REASON_RETURN) lim[p]=lim[p]+1 end
				elseif lc==2 then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_RTOHAND)
					local g=eg:FilterSelect(p,sumexcess,-lim[p]+lim[p+2],-lim[p]+lim[p+2],nil,p,lc)
					Duel.NegateSummon(g)
					for nc in aux.Next(g) do Duel.SendtoHand(nc,p,REASON_RULE+REASON_RETURN) lim[p]=lim[p]+1 end
					Duel.ShuffleHand(p)
				elseif lc==16 then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
					local g=eg:FilterSelect(p,sumexcess,-lim[p]+lim[p+2],-lim[p]+lim[p+2],nil,p,lc)
					Duel.NegateSummon(g)
					Duel.SendtoGrave(g,REASON_RULE+REASON_RETURN)
					lim[p]=lim[p]+#g
				elseif lc==32 then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
					local g=eg:FilterSelect(p,sumexcess,-lim[p]+lim[p+2],-lim[p]+lim[p+2],nil,p,lc)
					Duel.NegateSummon(g)
					for nc in aux.Next(g) do Duel.Remove(nc,nc:GetPreviousPosition(),REASON_RULE+REASON_RETURN) lim[p]=lim[p]+1 end
				else
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
					local g=eg:FilterSelect(p,sumexcess,-lim[p]+lim[p+2],-lim[p]+lim[p+2],nil,p,lc)
					Duel.NegateSummon(g)
					for nc in aux.Next(g) do 
						if nc:IsSummonType(SUMMON_TYPE_PENDULUM) and nc:IsPreviousPosition(POS_FACEUP) then
							Duel.SendtoExtraP(nc,nil,REASON_RULE+REASON_RETURN)
						else
							Duel.SendtoDeck(nc,nil,nc:GetPreviousSequence(),REASON_RULE+REASON_RETURN)
						end
						lim[p]=lim[p]+1
					end
				end
			end
		end
	end
end
if not global_check then
	global_check=true
	lim={3,0,0}
	lim[0]=3
	--summon count limit
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(sumlimit)
	Duel.RegisterEffect(e2,0)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e3,0)
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge1:SetOperation(resetop)
	Duel.RegisterEffect(ge1,0)
	local ge2=Effect.GlobalEffect()
	ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ge2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge2:SetOperation(checkop)
	Duel.RegisterEffect(ge2,0)
    local e4=ge2:Clone()
    e4:SetCode(EVENT_SUMMON_SUCCESS)
	Duel.RegisterEffect(e4,0)
	local ge3=e4:Clone()
	ge3:SetCode(EVENT_SPSUMMON_NEGATED)
	Duel.RegisterEffect(ge3,0)
	local ge4=e4:Clone()
	ge4:SetCode(EVENT_SUMMON_NEGATED)
	Duel.RegisterEffect(ge4,0)
end
